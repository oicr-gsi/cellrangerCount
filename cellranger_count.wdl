version 1.0

workflow cellranger_count {
  input {
    String runID
    String samplePrefix
    String fastqDirectory
    String transcriptomeDirectory
    String localMem
  }
  call count {
    input:
      runID = runID,
      samplePrefix = samplePrefix,
      fastqDirectory = fastqDirectory,
      transcriptome = transcriptomeDirectory,
      localMem = localMem
  }
}

task count {
  input {
    String? modules = "cellranger"
	String? cellranger = "cellranger"
    String runID
    String samplePrefix
    String fastqDirectory
    String transcriptome
    String? localMem = "2"
  }

  command <<<
   ~{cellranger} count \
    --id "~{runID}" \
    --fastq "~{fastqDirectory}" \
    --sample "~{samplePrefix}" \
    --transcriptome "~{transcriptome}" \
    --localmem "~{localMem}"
  >>>

  runtime {
    memory: "~{localMem}"
    modules: "~{modules}"
  }
}

 
