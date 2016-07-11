# role

The role module holds all the roles to be assigned to nodes or node groups.

Each role class will only include classes from the profile module. For example:

```
class role::blog {
  include profile::common
  include profile::wordpress
}
```
