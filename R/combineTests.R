#' @export
#' @importFrom S4Vectors DataFrame
#' @importFrom stats p.adjust
combineTests <- function(ids, tab, weight=NULL, pval.col=NULL, fc.col=NULL)
# Computes a combined FDR by assembling their group numbers and computing the
# average log-FC, average log-CPM and Simes' p-value for each cluster. The idea 
# is to test the joint null for each cluster, and then use that to compute the 
# FDR across all clusters. Clusters can be formed by whatever means are deemed 
# necessary (e.g. mergeWindows below, or using peaks).
# 
# written by Aaron Lun
# created 30 July 2013
{
    input <- .check_test_inputs(ids, tab, weight)
    ids <- input$ids
    tab <- input$tab
    groups <- input$groups
    weight <- input$weight
 
	# Running the clustering procedure.
    fc.col <- .parseFCcol(fc.col, tab) 
    is.pval <- .getPValCol(pval.col, tab)
	out <- .Call(cxx_get_cluster_stats, as.list(tab[fc.col]), tab[[is.pval]], ids, weight, 0.5)

	combined <- DataFrame(out[[1]], out[[2]], out[[3]], p.adjust(out[[3]], method="BH"), row.names=groups)
	colnames(combined) <- c("nWindows", sprintf("%s.%s", rep(colnames(tab)[fc.col], each=2), c("up", "down")), 
        colnames(tab)[is.pval], "FDR")

    # Adding direction.
    if (length(fc.col)==1L) {
        labels <- c("mixed", "up", "down")
        combined$direction <- labels[out[[4]] + 1L]
    }
    return(combined)
}
