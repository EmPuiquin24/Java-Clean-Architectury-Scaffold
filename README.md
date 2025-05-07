# Java-Clean-Architectury-Scaffold
Simple Zsh script to scaffold domain, application, and infrastructure layers for Clean Architecture projects and also a initial template for every Entity, EntityController, EntityService and EntityRepository file.

## Features
- Creates a folder for each entity in the current directory.
- Creates `domain/`, `application/`, and `infrastructure/` layers for each entity folder.
- Creates `Entity`, `EntityController`, `EntityService`, and `EntityRepository/`for each Entity.
- Auto-generates `.java` files with appropriate `package` declarations.
- Detects current project structure (e.g. `src/main/java/...`) to build correct package names.

## Usage
For example, we want to create a `User` and `Company` entity in the `.../com/example/autostructure folder`.
- Navigate into `src/main/java/com/example/autostructure` folder and paste the `create_layers.sh`file .
- Edit the script file so It should look like this:

```bash
#!/bin/zsh

...

# Set the entities you want to create starting in the 10th line

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
