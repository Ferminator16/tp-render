# Étape 1 : compilation avec Maven
FROM docker.io/library/maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
# Optionnel : options Maven (ex. proxy d'entreprise), vide par défaut (cas de Render)
ARG MAVEN_OPTS=""
ENV MAVEN_OPTS=${MAVEN_OPTS}
COPY pom.xml .
RUN mvn -q dependency:go-offline
COPY src ./src
RUN mvn -q package -DskipTests

# Étape 2 : image d'exécution légère
FROM docker.io/library/eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/demo-render-1.0.0.jar app.jar
# Limite la mémoire JVM (instance gratuite : 512 Mo)
ENV JAVA_TOOL_OPTIONS="-Xmx300m"
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
