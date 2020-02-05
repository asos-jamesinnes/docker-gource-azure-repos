FROM utensils/opengl:stable
RUN set -xe; \
    apk --update add --no-cache --virtual .runtime-deps \
    bash ffmpeg git gource llvm7-libs \
    gcc jq libffi-dev musl-dev openssl-dev python-dev py-pip python make; \
    pip --no-cache-dir install azure-cli;
ENV ORG="asos"
COPY ./entrypoint.sh .
ENTRYPOINT ["./entrypoint.sh"]