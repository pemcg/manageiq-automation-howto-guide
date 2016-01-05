## Classes, Schemas, Instances & Relationships

### Classes
A _Class_ is similar to a template, it contains a generic definition for a set of automation operations. Each Class has a _Schema_, that defines the variables, states, relationships or methods that Instances of the class will use.

### Schemas
A _Schema_ is made up of a number of elements, or _fields_. A schema often has just one entry - to run a single Method - but in many cases it has several components, for example:
<br> <br>

![Screenshot](images/screenshot4.png)

<br>
#### Adding or Editing a Schema
Each field is added or edited in the schema editor by specifying the field **Type** from a drop-down list...
<br> <br>

![Screenshot](images/screenshot5.png)

<br>
...and the field **Data Type** from a drop-down list:
<br> <br>

![Screenshot](images/screenshot6.png)

<br>
We can define default values for fields in a class schema, which will be inherited by all instances created from the class, but can be optionally over-ridden in the schema of any particular instance.

### Instances

An _Instance_ is a specific "clone" of the generic class, and is the entity run by the Automation Engine. An Instance contains a copy of the Class schema but with actual values of the fields filled in.

### Relationships

One of the schema field types is _Relationship_, and these are links to other Instances elsewhere in the Automation Datastore. We often use relationships as a way of chaining Instances together, and relationship values can accept variable substitutions for flexibility, for example:
<br> <br>

![Screenshot](images/screenshot7.png)
