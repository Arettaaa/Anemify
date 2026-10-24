enum RiskCategory {
  rendah('rendah'),
  perluPerhatian('perlu_perhatian'),
  tinggi('tinggi');

  const RiskCategory(this.key);

  /// Sama dengan kunci di fusion_config.json.
  final String key;
}