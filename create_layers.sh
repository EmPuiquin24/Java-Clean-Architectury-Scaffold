#!/bin/zsh

if [[ "$PWD" == *"src/main/java/"* ]]; then
    RELATIVE_PATH=${PWD#*src/main/java/}
    BASE_PACKAGE=$(echo "$RELATIVE_PATH" | tr '/' '.')
else
    BASE_PACKAGE=$(basename "$PWD" | tr '[:upper:]' '[:lower:]')
fi

# Set your entities here, replace examples with your actual entity names. You can add more entities as needed.
ENTITIES=(
    "Example1" 
    "Example2"
    "Example3")

for ENTITY in "${ENTITIES[@]}"
do
    echo "📦 Creating folder for: $ENTITY"

    mkdir -p "${ENTITY}/domain"
    mkdir -p "${ENTITY}/application"
    mkdir -p "${ENTITY}/infrastructure"

    echo "package ${BASE_PACKAGE}.${ENTITY}.domain;

public class ${ENTITY} {
}
" > "${ENTITY}/domain/${ENTITY}.java"

    echo "package ${BASE_PACKAGE}.${ENTITY}.domain;

public class ${ENTITY}Service {
}
" > "${ENTITY}/domain/${ENTITY}Service.java"

    echo "package ${BASE_PACKAGE}.${ENTITY}.application;

public class ${ENTITY}Controller {
}
" > "${ENTITY}/application/${ENTITY}Controller.java"

    echo "package ${BASE_PACKAGE}.${ENTITY}.infrastructure;

public interface ${ENTITY}Repository {
}
" > "${ENTITY}/infrastructure/${ENTITY}Repository.java"

done

echo "✅ Structure correctly created"

