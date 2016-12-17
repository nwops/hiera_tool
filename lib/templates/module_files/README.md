# File Object Serialization Generator

Serializes any given object mapping to a file.  For ever scope defined a new
file will be generated under a new directory for the scope.


## Setup

### 1. Define the output_object_files map
In the `common.yaml` file you need to define a new hash
called `output_object_files`.  In this hash you should define
a set of key/value pairs that tell the script which mapping to output
to a file.  The value of the pair should should be the name of the file.
The extension of the file `.json` or `.yaml` will determine which serialization
to use when encoding the object.

Example:

```
output_object_files:
  giant_object_mapping: 'giant_output_mapping.json'
```

The script will loop through each mapping and generate a output file for each
scope.

### 2. Define the mappping of each object
With the output_object_files map defined above we need to also create
a map for each mapping we used in the `output_object_files` map.  This mapping
is defined by you.  It should represent your data structure.  In the example below
we map `workflows` to a `alias` function which causes hiera to interpolate the key
by looking in the hierarchy for the key in order to return the value.
and  the key

```
workflows:
  workflow_a:
    url: 'https://www.something.com'


giant_object_mapping:
  workflows: "%{alias('workflows')}"
```

Where the JSON output becomes

```
{
  "workflows": {
    "workflow_a": {
      "url": "https://www.something.com"
    }
  }
}
```

### 3. Create the scopes
In order for hiera to correctly find the keys in the hierarchy we need to provide
a scope for hiera to use.  This scope is defined by you and based on your hierarchical
structure in `hiera.yaml`.  You should only defined keys in the scope for every
variable you use in the `hiera.yaml` mapping and any other variables you might
interpolate in hiera values.  This must be a hash with key/value pairs where the values
must be strings.

It is mandatory that the mapping name be called `env_scopes`

```
env_scopes:
  env_1:
    provisioning_env: prov_env_a
    customer_env: environment_a
    datacenter: datacentera_a
```


## Usage
To generate the serialized files just run the `ruby_test.rb` file which will generate
all the files under the current local directory.
