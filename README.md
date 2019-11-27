# cellrangerCount

Workflow for generating single cell feature counts for a single library.

## Overview

## Usage

### Cromwell
```
java -jar cromwell.jar run cellrangerCount.wdl --inputs inputs.json
```

### Inputs

#### Required workflow parameters:
Parameter|Value|Description
---|---|---
`runID`|String|A unique run ID string.
`samplePrefix`|String|Sample name (FASTQ file prefix). Can take multiple comma-separated values.
`fastqDirectory`|String|Path to folder containing fastq files.
`transcriptomeDirectory`|String|Path to Cell Ranger compatible transcriptome reference.
`localMem`|String|Restricts cellranger to use specified amount of memory (in GB) to execute pipeline stages. By default, cellranger will use 90% of the memory available on your system.


#### Optional workflow parameters:
Parameter|Value|Default|Description
---|---|---|---


#### Optional task parameters:
Parameter|Value|Default|Description
---|---|---|---
`count.modules`|String?|"cellranger"|Environment module name to load before command execution.
`count.cellranger`|String?|"cellranger"|


### Outputs

Output | Type | Description
---|---|---
`possortedGenomeBam`|File|BAM file.
`possortedGenomeBaiIndex`|File|BAM index.
`cloupe`|File|Loupe Cell Browser file.
`metricsSummary`|File|Run summary CSV.
`featureBcMatrix`|File|Raw and filtered feature-barcode matrices MEX.
`analysis`|File|Secondary analysis output CSV.
`geneMatricesMoleculeInfoH5`|File|Raw and filtered feature-barcode matrices HDF5 and per-molecule read information.


## Niassa + Cromwell

This WDL workflow is wrapped in a Niassa workflow (https://github.com/oicr-gsi/pipedev/tree/master/pipedev-niassa-cromwell-workflow) so that it can used with the Niassa metadata tracking system (https://github.com/oicr-gsi/niassa).

* Building
```
mvn clean install
```

* Testing
```
mvn clean verify \
-Djava_opts="-Xmx1g -XX:+UseG1GC -XX:+UseStringDeduplication" \
-DrunTestThreads=2 \
-DskipITs=false \
-DskipRunITs=false \
-DworkingDirectory=/path/to/tmp/ \
-DschedulingHost=niassa_oozie_host \
-DwebserviceUrl=http://niassa-url:8080 \
-DwebserviceUser=niassa_user \
-DwebservicePassword=niassa_user_password \
-Dcromwell-host=http://cromwell-url:8000
```

## Support

For support, please file an issue on the [Github project](https://github.com/oicr-gsi) or send an email to gsi@oicr.on.ca .

_Generated with wdl_doc_gen (https://github.com/oicr-gsi/wdl_doc_gen/)_
