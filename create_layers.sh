#!/bin/zsh
if [[ "$PWD" == *"src/main/java/"* ]]; then
    RELATIVE_PATH=${PWD#*src/main/java/}
    BASE_PACKAGE=$(echo "$RELATIVE_PATH" | tr '/' '.')
else
    BASE_PACKAGE=$(basename "$PWD" | tr '[:upper:]' '[:lower:]')
fi

# Set your entities here, replace examples with your actual entity names. You can add more entities as needed.
ENTITIES=(
    "Entity-1"
    "Entity-2"
    "Entity-3")

# Function to convert a string to CamelCase (first letter in lowercase)
to_camel_case() {
    local input="$1"
    input=$(echo "$input" | tr '[:upper:]' '[:lower:]')  # Convert to lowercase
    input=$(echo "$input" | sed -r 's/_([a-z])/\U\1/g')  # Capitalize letters after underscores only
    echo "$input"
}

# Function to convert a string to PascalCase (first letter in uppercase)
to_pascal_case() {
    local input="$1"
    input=$(echo "$input" | tr '[:upper:]' '[:lower:]')  # Convert to lowercase first
    input=$(echo "$input" | sed -r 's/(^|_)([a-z])/\U\2/g')  # Capitalize first letter and after underscores
    echo "$input"
}

for ENTITY in "${ENTITIES[@]}"
do
    # Get the folder name in lowercase (for folder structure)
    FOLDER_NAME=$(echo "$ENTITY" | tr '[:upper:]' '[:lower:]')

    # Get the class names in Pascal case (first letter in uppercase)
    ENTITY_CLASS=$(to_pascal_case "$ENTITY")
    ENTITY_SERVICE_CLASS="${ENTITY_CLASS}Service"
    ENTITY_CONTROLLER_CLASS="${ENTITY_CLASS}Controller"
    ENTITY_REPOSITORY_INTERFACE="${ENTITY_CLASS}Repository"

    echo "📦 Creating folder for: $FOLDER_NAME"
    # Create directories
    mkdir -p "${FOLDER_NAME}/domain"
    mkdir -p "${FOLDER_NAME}/application"
    mkdir -p "${FOLDER_NAME}/infrastructure"

    # Create the Java classes with PascalCase
    echo "package ${BASE_PACKAGE}.${FOLDER_NAME}.domain;

import jakarta.persistence.Entity;
import lombok.*;

@Entity
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
public class ${ENTITY_CLASS} {
}
" > "${FOLDER_NAME}/domain/${ENTITY_CLASS}.java"

    echo "package ${BASE_PACKAGE}.${FOLDER_NAME}.domain;

public class ${ENTITY_SERVICE_CLASS} {
}
" > "${FOLDER_NAME}/domain/${ENTITY_SERVICE_CLASS}.java"

    echo "package ${BASE_PACKAGE}.${FOLDER_NAME}.application;

public class ${ENTITY_CONTROLLER_CLASS} {
}
" > "${FOLDER_NAME}/application/${ENTITY_CONTROLLER_CLASS}.java"

    echo "package ${BASE_PACKAGE}.${FOLDER_NAME}.infrastructure;

public interface ${ENTITY_REPOSITORY_INTERFACE} {
}
" > "${FOLDER_NAME}/infrastructure/${ENTITY_REPOSITORY_INTERFACE}.java"

done

echo "✅ Structure correctly created"
