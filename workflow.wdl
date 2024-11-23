version 1.0

workflow setid_VCFs {

	meta {
	author: "Phuwanat Sakornsakolpat"
		email: "phuwanat.sak@mahidol.edu"
		description: "setid VCF"
	}

	 input {
		File vcf_file
	}

	call run_setid { 
			input: vcf = vcf_file
	}

	output {
		File setid_vcf = run_setid.out_vcf
		File setid_tbi = run_setid.out_tbi
	}

}

task run_setid {
	input {
		File vcf
		Int memSizeGB = 8
		Int threadCount = 2
		Int diskSizeGB = 8*round(size(vcf, "GB")) + 20
	String out_name = basename(vcf, ".vcf.gz")
	}
	
	command <<<
	bcftools annotate --set-id '%CHROM\_%POS\_%REF\_%FIRST_ALT' -Oz -o ~{out_name}.id.vcf.gz ~{vcf}
	tabix -p vcf ~{out_name}.id.vcf.gz
	>>>

	output {
		File out_vcf = select_first(glob("*.id.vcf.gz"))
		File out_tbi = select_first(glob("*.id.vcf.gz.tbi"))
	}

	runtime {
		memory: memSizeGB + " GB"
		cpu: threadCount
		disks: "local-disk " + diskSizeGB + " SSD"
		docker: "quay.io/biocontainers/bcftools@sha256:f3a74a67de12dc22094e299fbb3bcd172eb81cc6d3e25f4b13762e8f9a9e80aa"   # digest: quay.io/biocontainers/bcftools:1.16--hfe4b78e_1
		preemptible: 2
	}

}