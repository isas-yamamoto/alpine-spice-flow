# alpine-spice-flow

## Overview

"FLOW" is a Field Of View Visualizer for SPICE users developed by ISAS/JAXA.
https://darts.isas.jaxa.jp/planet/tools/flow/

This image is prepared to be easy to use for Docker users.

## How to use this image

flow_se command can be launched as below:
```bash
$ docker run --rm -t -i alpine-spice-flow:1.0 flow_se -V
```

flow_ig command is also executed as well:
```bash
$ docker run --rm -t -i alpine-spice-flow:1.0 flow_ig -V
```
