# Illinois Campaign Cash loader

Load Illinois campaign fundraising data from the Illinois State Board of Elections.

## Requirements

* GNU Make
* Python 3 (tested on 3.6 and 3.7)

## Install


Install using the `requirements.txt` file:

```
pip install -r requirements.txt
```


### Load all

Download, process, and load.

```
make all
```

### Paralellization

This incantation should do the trick. It parallelizes downloading and data loading across 4 cores, while running database creation and view creation serially.

```
make -j4 all
```
