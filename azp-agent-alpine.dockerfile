FROM alpine:latest

# Set environment variables
ENV TARGETARCH="linux-musl-x64"

# Update and install dependencies
RUN apk update
RUN apk upgrade
RUN apk add --no-cache \
    ca-certificates \
    icu-libs \
    bash \
    curl \
    openssl \
    git \
    ncurses-terminfo-base \
    krb5-libs \
    zlib \
    jq && \
    rm -rf /var/cache/apk/*

# Set the working directory
WORKDIR /azp/

# Copy start file
COPY ./start.sh ./

# Make start script executable
RUN chmod +x ./start.sh

# Install .NET 8
RUN curl -sSL https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    ./dotnet-install.sh --channel 8.0 --install-dir /usr/share/dotnet && \
    ./dotnet-install.sh --channel 7.0 --install-dir /usr/share/dotnet && \
    ./dotnet-install.sh --channel 6.0 --install-dir /usr/share/dotnet && \
    rm dotnet-install.sh

# Install PowerShell 7
RUN curl -L https://github.com/PowerShell/PowerShell/releases/download/v7.4.4/powershell-7.4.4-linux-musl-x64.tar.gz -o /tmp/powershell.tar.gz
RUN mkdir -p /opt/microsoft/powershell/7 && \
    tar -xvf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 && \
    chmod +x /opt/microsoft/powershell/7/pwsh && \
    ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh && \
    rm /tmp/powershell.tar.gz

# Install Node.js 20
RUN curl -sL https://unofficial-builds.nodejs.org/download/release/v20.16.0/node-v20.16.0-linux-x64-musl.tar.gz -o /tmp/node.tar.gz && \
    tar -xzf /tmp/node.tar.gz -C /usr/local --strip-components=1 && \
    rm /tmp/node.tar.gz

# Create a user to run the agent
RUN adduser -D agent
RUN chown agent ./
USER agent

# Copy the application
ENTRYPOINT [ "./start.sh" ]