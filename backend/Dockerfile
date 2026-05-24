# Build
FROM maven:3.9-eclipse-temurin-21-alpine AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
# -Dmaven.test.skip=true: test kaynakları + testcontainers vb. indirilmez (jar daha hızlı / daha az ağ).
# --mount=cache: Maven repo önbelleği; tekrar build’de Central’a daha az gider.
# İkinci satır: "Premature end of Content-Length…" gibi kesilen indirmelerde bir kez yeniden dene.
RUN --mount=type=cache,target=/root/.m2 \
    mvn -B -q -Dmaven.test.skip=true package \
    || (echo "[maven] retry package after network/partial jar..." && sleep 12 \
        && mvn -B -q -Dmaven.test.skip=true package)

# Run
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/target/timebank-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
