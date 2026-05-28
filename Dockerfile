# ── Stage 1: Build the WAR ──────────────────────────────────────────────────
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /app
COPY pom.xml .
# Download dependencies first (layer caching)
RUN mvn dependency:go-offline -B

COPY src ./src
COPY civicfix.db .
RUN mvn package -DskipTests -B

# ── Stage 2: Run on Tomcat ───────────────────────────────────────────────────
FROM tomcat:9.0-jdk17-temurin

# Remove the default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy our WAR as ROOT.war so it runs at context path "/"
COPY --from=builder /app/target/CivicFix.war /usr/local/tomcat/webapps/ROOT.war

# Copy the SQLite database to a persistent-friendly location
RUN mkdir -p /data
COPY --from=builder /app/civicfix.db /data/civicfix.db

# Tell the app where to find the database
ENV CIVICFIX_DB_PATH=/data/civicfix.db

# Expose port 8080
EXPOSE 8080

CMD ["catalina.sh", "run"]
