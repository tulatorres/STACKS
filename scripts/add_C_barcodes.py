#!/usr/bin/env python

# Open the input file
with open('frogs_barcodes_stacks.txt', 'r') as f:
    # Read the lines of the file
    lines = f.readlines()

# Open a new file to write the modified barcodes
with open('modified_frogs_barcodes_stacks.txt', 'w') as f_out:
    # Iterate through each line
    for line in lines:
        # Split the line into barcode and sample ID
        barcode, sample_id = line.strip().split('\t')
        # Add 'C' to the end of the barcode
        modified_barcode = barcode + 'C'
        # Write the modified barcode and sample ID to the output file
        f_out.write(f"{modified_barcode}\t{sample_id}\n")

print("Modification complete. Modified barcodes saved to 'modified_frogs_barcodes_stacks.txt'.")
