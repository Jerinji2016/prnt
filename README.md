# prnt

prnt is a flutter application to listen to a redis server for print notifications from Dineazy, EazyPMS
which if forwarded to POS printer connected to this application.

## Getting Started

prnt app has custom implementation for printer packages such as `pos_printer_manager` and `blue_thermal_printer`.  
These packages are added to the project as git submodules.

To know more on git submodules, refer [this video](https://www.youtube.com/watch?v=gSlXo2iLBro).  

After cloning the repo from a git, its important to explicitly fetch all submodule dependencies. For
doing the same run:

```shell
  git submodule update --init
```

> Note: Packages are better maintaining public in github since its easy to sync with the actual remote fork.