# RailsGraphQLConverter

## Usage
Include this project within your project folder.
After creating one or more ApplicationRecord models run `$rails db:create` and `$rails db:migrate`, then you can generate the corresponding types, inputs and mutations running:
```sh
$rails generate type_helper 'ModelName'
```
See usage with:
```sh
$rails generate type_helper --help
```

This will create:
- type files (enums included, if any)
- mutations files (create, update, delete)
- input file

## Dependencies
The program will automatically find any relation asking you to generate the files as above. 
You can skip this step by adding the argument --no-dependencies, eg: `rails generate type_helper StudentsClass --no-dependencies`

The generated files depends on a few other files (see: /type_helper/templates/dependencies/) that will be automatically included. 
Note that a base implemetation of common GraphQL objects is provided, you are free to extend these classes.

## Options
Available options are:

- `--no-type` 
- `--no-enums`
- `--no-input`
- `--no-mutations`
- `--no-dependencies`