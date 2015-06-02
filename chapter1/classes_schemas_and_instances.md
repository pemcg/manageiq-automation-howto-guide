## Classes, Schemas and Instances

### Classes
A **class** is similar to a template, it contains a generic definition for a set of automation operations. Each class has a **schema**, that defines the variables, states, relationships or methods that **instances** of the class will use. A schema often has just one entry - to run a single **method** - but in many cases it has several components, e.g.

![Screenshot](images/schema1.png)

### Schemas
A schema is made up of a number of elements, or _fields_, and each field is added or edited in the schema editor by specifying the field _Type_ from a drop-down list ...

![Screenshot](images/schema2.png)

...and the field _Data Type_ from a drop-down list:

![Screenshot](images/schema3.png)

We can define default values for fields in a class schema, which will be inherited by all instances created from the class, but can be optionally over-ridden in the schemas of any particular instance.

### Instances

An **instance** is a specific "clone" of the generic class, and is the entity run in the context of _$evm.root_ by the Automation Engine. An instance contains a copy of the class schema but with actual values of the fields filled in.

### Relationships

One of the schema field types is **Relationship**, and these are links to other instances elsewhere in the Automation Datastore. We often use relationships as a way of chaining instances together, and relationship values can accept variable substitutions for flexibility as shown below:

![Screenshot 1](images/relationships.png)