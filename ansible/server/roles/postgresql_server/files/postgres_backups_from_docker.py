from subprocess import run
from datetime import datetime
import os
import json

def get_docker_containers():
    res = run(["docker", "ps",  "--format", "{{.Names}}"], capture_output=True)
    container_names = [out for out in res.stdout.decode("utf-8").split("\n") if len(out) > 0]
    return container_names

def get_container_env(container_name):
    env_vars = {}
    res = run(["docker", "exec", container_name, "env"], capture_output=True)
    lines = [out for out in res.stdout.decode("utf-8").split("\n") if len(out) > 0]
    for ln in lines:
        eq_idx = ln.index('=')
        if eq_idx > 0:
            env_vars[ln[:eq_idx]] = ln[eq_idx+1:]
    return env_vars

def find_postgres_vars(env_vars):
    pg_var_names = {
        'POSTGRESQL_HOST': 'host',
        'POSTGRESQL_NAME': 'name',
        'POSTGRESQL_USER': 'user',
        'POSTGRESQL_PASSWORD': 'password',
    }
    pg_vars = {}
    for k, v in pg_var_names.items():
        if k not in env_vars:
            return None
        pg_vars[v] = env_vars[k]
    return pg_vars


def backup_database(host, name, user, password, s3_bucket):
    when = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
    backup_dir = f"/var/dbbackups/files/{name}"

    # delete any existing previous backup dir:
    run(['rm', '-rf', backup_dir])
    # create the clean backup_dir
    os.makedirs(backup_dir)

    with open(f"{backup_dir}/{name}.psql", "w") as fp:
        run(['pg_dump', name, '-U', user],
            env={'PGPASSWORD': password},
            stdout=fp)

    # TODO: Hash file and check if it has changed from the last
    # backup.

    # create a tar file
    tar_file = f'/var/dbbackups/{when}_{name}.tar.gz'
    run(['tar', '-cvzf', tar_file, '-C', backup_dir, backup_dir])

    # check if we have an s3conf file
    if os.path.exists("/var/dbbackups/s3backups.conf"):
        # upload tar file
        run(['s3cmd', '-c', '/var/dbbackups/s3backups.conf', 'put',
            f'/var/dbbackups/{when}_{name}.tar.gz',
            s3_bucket])
    os.unlink(tar_file)

if __name__ == '__main__':
    backups_dir = os.path.dirname(__file__)
    if 'PGBK_DIR' in os.environ:
        backups_dir = os.environ['PGBK_DIR']

    # Read data from the config file
    conf_file = os.path.join(backups_dir, 'postgres_backups_config.json')
    with open(conf_file, 'r') as fp:
        conf = json.load(fp)
    s3_bucket = conf['s3_bucket']

    for dc in get_docker_containers():
        env_vars = get_container_env(dc)
        pg_vars = find_postgres_vars(env_vars)
        if pg_vars is not None:
            pg_vars['s3_bucket'] = s3_bucket
            backup_database(**pg_vars)
