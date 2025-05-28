#!/bin/bash
export YAPLIBDIRS=/workspaces/project_tadb_fcup_20242025/gis_functions
exec yap -L /workspaces/project_tadb_fcup_20242025/gis_functions/yap2c_function.so "$@"
