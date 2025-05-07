# Java-Clean-Architectury-Scaffold
Simple Zsh script to scaffold domain, application, and infrastructure layers for Clean Architecture projects.

## Features
- Creates a folder for each entity in the current directory.
- Creates `domain/`, `application/`, and `infrastructure/` layers for each entity folder.
- Creates `Entity`, `EntityController`, `EntityService`, and `EntityRepository/`for each Entity.
- Auto-generates `.java` files with appropriate `package` declarations.
- Detects current project structure (e.g. `src/main/java/...`) to build correct package names.

## Usage
- Paste the script file into the folder where you want to create the layers. 
For example, if you want to create it in the `src/main/java/com/example:
- `Navigate into `src/main/java/com/example` folder.
- Edit the script file so It should look like this:

```bash
#!/bin/zsh

...

# Set the entities you want to create

ENTITIES=(
    "User"
    "Company"
)

````
- Give the script execute permissions with the command:
```bash
chmod +x create_layers.sh
```
- Run the script with the command:
```bash
./create_layers.sh
```

This script should generate the following structure:
```
com/example/autostructure/
├── User/
│   ├── domain/
│   │   ├── User.java
│   │   └── UserService.java
│   ├── application/
│   │   └── UserController.java
│   └── infrastructure/
│       └── UserRepository.java
└── Company/
    ├── domain/
    │   ├── Company.java
    │   └── CompanyService.java
    ├── application/
    │   └── CompanyController.java
    └── infrastructure/
        └── CompanyRepository.java
```
