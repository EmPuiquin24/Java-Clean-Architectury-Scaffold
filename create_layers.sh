#!/bin/zsh
if [[ "$PWD" == *"src/main/java/"* ]]; then
    RELATIVE_PATH=${PWD#*src/main/java/}
    BASE_PACKAGE=$(echo "$RELATIVE_PATH" | tr '/' '.')
else
    BASE_PACKAGE=$(basename "$PWD" | tr '[:upper:]' '[:lower:]')
fi

# Set your entities here, replace examples with your actual entity names. You can add more entities as needed.
ENTITIES=(
    "Entity1"
    "Entity2"
    "Entity3"
)

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

# Create configuration folder and files
echo "⚙️  Creating configuration folder..."
mkdir -p "configuration"

# Create BeanUtils.java
echo "package ${BASE_PACKAGE}.configuration;

import org.modelmapper.ModelMapper;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
public class BeanUtils {

    @Bean
    public ModelMapper modelMapper() {
        return new ModelMapper();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
" > "configuration/BeanUtils.java"

# Create SecurityConfiguration.java
echo "package ${BASE_PACKAGE}.configuration;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.access.expression.method.DefaultMethodSecurityExpressionHandler;
import org.springframework.security.access.expression.method.MethodSecurityExpressionHandler;
import org.springframework.security.access.hierarchicalroles.RoleHierarchy;
import org.springframework.security.access.hierarchicalroles.RoleHierarchyImpl;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import org.sparky.sparkyai.jwt.domain.JwtAuthenticatorFilter;

import lombok.RequiredArgsConstructor;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfiguration {

    private final JwtAuthenticatorFilter jwtAuthenticatorFilter;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        return http.csrf(AbstractHttpConfigurer::disable)
                .cors(Customizer.withDefaults())
                .sessionManagement(manager -> manager.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .addFilterBefore(jwtAuthenticatorFilter, UsernamePasswordAuthenticationFilter.class)
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(\"/auth/**\").permitAll()
                        .anyRequest().authenticated())
                .build();
    }

    @Bean
    public static RoleHierarchy roleHierarchy() {
        return RoleHierarchyImpl
                .fromHierarchy(\"ROLE_SPARKY_ADMIN > ROLE_COMPANY_ADMIN \\n ROLE_COMPANY_ADMIN > ROLE_USER\"); // TODO: cambiar
    }

    @Bean
    public static MethodSecurityExpressionHandler methodSecurityExpressionHandler(RoleHierarchy roleHierarchy) {
        var expressionHandler = new DefaultMethodSecurityExpressionHandler();
        expressionHandler.setRoleHierarchy(roleHierarchy);
        expressionHandler.setDefaultRolePrefix(\"ROLE_\");
        return expressionHandler;
    }

    @Bean
    public WebMvcConfigurer corsMappingConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping(\"/**\")
                        .allowedOrigins(\"*\")
                        .allowedMethods(\"GET\", \"POST\", \"PUT\", \"DELETE\", \"HEAD\", \"PATCH\")
                        .maxAge(3600)
                        .allowedHeaders(\"*\")
                        .allowCredentials(false);
            }
        };
    }

}
" > "configuration/SecurityConfiguration.java"

# Create AsyncConfig.java
echo "package ${BASE_PACKAGE}.configuration;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;

@Configuration
@EnableAsync
public class AsyncConfig {

    @Bean(name = \"taskExecutor\")
    public Executor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(5);
        executor.setMaxPoolSize(10);
        executor.setQueueCapacity(50);
        executor.initialize();
        return executor;
    }

}
" > "configuration/AsyncConfig.java"

# Update application.properties
echo "📝 Updating application.properties..."

# Find the resources folder (at the same level as java folder)
if [[ "$PWD" == *"src/main/java/"* ]]; then
    RESOURCES_PATH="${PWD%/src/main/java/*}/src/main/resources"
else
    RESOURCES_PATH="../resources"
fi

PROPERTIES_FILE="${RESOURCES_PATH}/application.properties"

if [ -f "$PROPERTIES_FILE" ]; then
    # Save the first line
    FIRST_LINE=$(head -n 1 "$PROPERTIES_FILE")
    
    # Create the new content
    echo "$FIRST_LINE
server.port=8080

spring.datasource.url = jdbc:postgresql://\${DB_HOST}:\${DB_PORT}/\${DB_DATABASE}
spring.datasource.username = \${DB_USERNAME}
spring.datasource.password = \${DB_PASSWORD}

spring.jpa.hibernate.ddl-auto = update
spring.jpa.open-in-view = true
spring.jpa.properties.hibernate.enable_lazy_load_no_trans = true

jwt.secret = \${JWT_SECRET}
github.token = \${GITHUB_TOKEN}

spring.mail.host = \${MAIL_HOST}
spring.mail.port = \${MAIL_PORT}
spring.mail.username=\${MAIL_SMPT_USERNAME}
spring.mail.password=\${MAIL_SMPT_PASSWORD}
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true
" > "$PROPERTIES_FILE"
    
    echo "✅ application.properties updated successfully"
else
    echo "⚠️  Warning: application.properties not found at $PROPERTIES_FILE"
fi

echo "✅ Structure correctly created"
echo "⚙️  Configuration files created: BeanUtils.java, SecurityConfiguration.java, AsyncConfig.java"

