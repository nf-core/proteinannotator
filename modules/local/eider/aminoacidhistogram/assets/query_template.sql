COPY (
  WITH p AS (
    SELECT * FROM read_parquet('${parquet}/*.parquet')
  ),
  s AS (
    SELECT unnest(string_to_array(sequence, '')) AS aa FROM p
  ),
  h AS (
    SELECT unnest(map_entries(histogram(aa))) AS kv FROM s
  ),
  e AS (
    SELECT * from read_csv_auto('${amino_acid_properties}')
  )
  SELECT
    '${prefix}' AS id,
    h.kv['value'] AS count,
    e.amino_acid,
    e.one_letter_symbol,
    e.three_letter_symbol,
    e.class,
    e.chemical_polarity,
    e.net_charge,
    e.hydropathy_index,
    e.molecular_mass,
    e.abundance_in_proteins,
    e.standard_genetic_coding,
    e.hydrophobic,
    e.aromatic,
    e.aliphatic,
    e.small,
    e.hydrophilic,
    e.positively_charged,
    e.negatively_charged
  FROM
    h
  JOIN
    e
  ON
    h.kv['key'] = e.one_letter_symbol
)
TO '${prefix}.histogram.tsv' (HEADER, DELIMITER '\t')
