FROM golang:1.19-alpine
EXPOSE 8000
RUN mkdir /app &&  mkdir /appfiles
ENV APPFILES=/appfiles
COPY docker_served/* /appfiles/
COPY goserver/* /app/
WORKDIR /app
RUN go build -o /app/goserver .
CMD ["/app/goserver"]
HEALTHCHECK --interval=10s --timeout=10s --retries=2 \
    CMD wget -q -O /dev/null -o /dev/null localhost:8000/_/health
