FROM golang:alpine3.17 AS build

WORKDIR /app
COPY . .
RUN go build -o app

FROM alpine:3.17
WORKDIR /app
COPY --from=build /app/app .
CMD [ "./app" ]
