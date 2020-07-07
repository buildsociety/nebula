FROM --platform=${BUILDPLATFORM:-linux/amd64} tonistiigi/xx:golang AS xgo
FROM --platform=${BUILDPLATFORM:-linux/amd64} golang:1.14-alpine as builder

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

COPY --from=xgo / /
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN printf "I am running on ${BUILDPLATFORM:-linux/amd64}, building for ${TARGETPLATFORM:-linux/amd64}\n$(uname -a)\n"

RUN apk --update --no-cache add \
        bash \
        build-base \
        gcc \
        git \
        make \
        sed \
 && rm -rf /tmp/* /var/cache/apk/*

RUN git clone --branch ${VERSION} https://github.com/slackhq/nebula /go/src/github.com/slackhq/nebula

WORKDIR /go/src/github.com/slackhq/nebula
RUN make BUILD_NUMBER="${VERSION#v}" build/$(echo ${TARGETPLATFORM:-linux/amd64} | sed -e "s/\/v/-/g" -e "s/\//-/g")/nebula
RUN mkdir -p /go/build/${TARGETPLATFORM:-linux/amd64}
RUN mv /go/src/github.com/slackhq/nebula/build/$(echo ${TARGETPLATFORM:-linux/amd64} | sed -e "s/\/v/-/g" -e "s/\//-/g")/nebula /go/build/${TARGETPLATFORM:-linux/amd64}/

FROM --platform=${TARGETPLATFORM:-linux/amd64} alpine:latest

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
ARG TARGETPLATFORM

LABEL maintainer="buildsociety" \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.url="https://github.com/buildsociety/nebula" \
      org.opencontainers.image.source="https://github.com/buildsociety/nebula" \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.vendor="buildsociety" \
      org.opencontainers.image.title="nebula" \
      org.opencontainers.image.description="Nebula is a scalable overlay networking tool with a focus on performance, simplicity and security from Slack" \
      org.opencontainers.image.licenses="MIT"

COPY --from=builder /go/build/${TARGETPLATFORM:-linux/amd64}/nebula /usr/local/bin/nebula
RUN nebula -version

VOLUME ["/config"]

ENTRYPOINT [ "/usr/local/bin/nebula" ]
CMD []