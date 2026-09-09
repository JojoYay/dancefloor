#!/usr/bin/env bash
set -euo pipefail

# The project targets Java 14 (pom.xml <java.version>14) with Spring Boot 2.3.1 and
# Lombok 1.18.12, which cannot run on the default image's JDK 21 (the compiler module
# is strongly encapsulated on JDK 16+). Install Azul Zulu JDK 14 into the home
# directory so it is captured by the environment snapshot / build.
JDK_DIR="$HOME/.jdks/zulu14"
JDK_URL="https://cdn.azul.com/zulu/bin/zulu14.29.23-ca-jdk14.0.2-linux_x64.tar.gz"

if [ ! -x "$JDK_DIR/bin/java" ]; then
  echo "Installing Azul Zulu JDK 14 to $JDK_DIR ..."
  rm -rf "$JDK_DIR"
  mkdir -p "$JDK_DIR"
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/zulu14.tar.gz" "$JDK_URL"
  tar -xzf "$tmp/zulu14.tar.gz" -C "$JDK_DIR" --strip-components=1
  rm -rf "$tmp"
else
  echo "JDK 14 already present at $JDK_DIR"
fi

export JAVA_HOME="$JDK_DIR"
export PATH="$JAVA_HOME/bin:$PATH"
java -version

chmod +x ./mvnw || true

# Build the backend and warm the local Maven cache. The frontend-maven-plugin is
# skipped on purpose: the "my-first-app" React sources are an unavailable submodule,
# and the compiled bundle is already committed under src/main/resources/public.
./mvnw -B -ntp -Dskip.installnodenpm=true -Dskip.npm=true -DskipTests clean package
