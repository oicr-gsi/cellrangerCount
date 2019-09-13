version 1.0

workflow cellranger_count {
  input {
    String runID
    String samplePrefix
    String fastqDirectory
    String referenceDirectory
    String localMem
  }
  call count {
    input:
      runID = runID,
      samplePrefix = samplePrefix,
      fastqDirectory = fastqDirectory,
      referenceDirectory = referenceDirectory,
      localMem = localMem
  }
}

task count {
  input {
    String? cellranger = "cellranger"
    String runID
    String samplePrefix
    String fastqDirectory
    String referenceDirectory
    String? localMem = 2
    String? modules ="cellranger"
  }

  command <<<
   ~{cellranger} count \
    --id "~(runID)" \
    --fastq "~(fastqDirectory)" \
    --sample "~(samplePrefix)" \
    --transcriptome "~(transcriptome)" \
    --localmem "~(localMem)"
  >>>

  runtime {
    memory: "2 GB"
    modules: "~{modules}"
  }
}

 
