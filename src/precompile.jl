using PrecompileTools
@setup_workload begin
    bib = """
    @article{klitzing1980new,
      doi = {10.1103/physrevlett.45.494},
      url = {https://doi.org/10.1103%2Fphysrevlett.45.494},
      year = 1980,
      month = {aug},
      publisher = {American Physical Society ({APS})},
      volume = {45},
      number = {6},
      pages = {494--497},
      author = {K. v. Klitzing and G. Dorda and M. Pepper},
      title = {New Method for High-Accuracy Determination of the Fine-Structure Constant Based on Quantized Hall Resistance},
      journal = {Physical Review Letters}
    }
    """
    @compile_workload begin
        _prettify_bib(bib, #=minimal=# true, #=abbreviate=# true)
    end
end