#!/usr/bin/env nextflow

params.seq = "$baseDir/data/BB11001.tfa"
params.out = "results" 
seq_ch = Channel.fromPath(params.seq)

process align {
  input: 
  file seq from seq_ch 
  output: 
  file '*.aln' into aln_ch
	
  """
  t_coffee -in $seq 
  """
  
}

process makeTree {
	publishDir params.out, mode: 'copy' 
	
	input: 
	file aln from aln_ch.toList() 
	output:
	file 'RAxML_bestTree.big' 

	"""
	t_coffee -profile $aln -output phy -outfile big.aln
	raxml -s big.aln -m PROTGAMMALG -n big
	"""
	
}


workflow.onComplete {
  println workflow.success ? "Done! Check result file at `${params.out}/RAxML_bestTree.big`" : 'Oops.. something went wrong'
}