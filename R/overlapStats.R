#' @importFrom S4Vectors queryLength queryHits subjectHits
.overlapStats <- function(olap, tab, o.weight=NULL, i.weight=NULL, 
                          type=c("combine", "best", "empirical", "mixed"), ...) {
	region.dex <- queryHits(olap)
	win.dex <- subjectHits(olap)

	# Setting up weights.
	if (is.null(o.weight)) { 
		if (!is.null(i.weight)) {
			o.weight <- i.weight[win.dex]
		}
	}

	type <- match.arg(type)
	if (type=="combine") { 
		output <- combineTests(region.dex, tab[win.dex,], weight=o.weight, ...)
	} else if (type=="best") { 
		output <- getBestTest(region.dex, tab[win.dex,], weight=o.weight, ...)
		output$best <- win.dex[output$best]
	} else if (type=="empirical") {
        output <- empiricalFDR(region.dex, tab[win.dex,], weight=o.weight, ...)
   	} else if (type=="mixed") {
        output <- mixedClusters(region.dex, tab[win.dex,], weight=o.weight, ...)
    } else {
        stop("invalid type")
    }

	# Filling in empties with NA's.
	nregions <- queryLength(olap)
	output <- .expandNA(output, nregions)

	return(output)
}

.expandNA <- function(tab, N) {
    expand.vec <- rep(NA_integer_, N)
    row.dex <- as.integer(rownames(tab))
    if (any(N <= 0L | row.dex > N)) { 
        stop("cluster IDs are not within [1, nregions]") 
    }
    expand.vec[row.dex] <- seq_along(row.dex)
    tab <- tab[expand.vec,,drop=FALSE]
    rownames(tab) <- as.character(seq_len(N))
    return(tab)
}

#' @export
combineOverlaps <- function(olap, tab, o.weight=NULL, i.weight=NULL, ...) 
# Wrapper around combineTests for Hits from findOverlaps,
# when windows are overlapped with regions.
#
# written by Aaron Lun
# created 25 March 2015
# last modified 26 March 2015
{
	.overlapStats(olap, tab, o.weight=o.weight, i.weight=i.weight, type="combine", ...)
}

#' @export
getBestOverlaps <- function(olap, tab, o.weight=NULL, i.weight=NULL, ...) 
# Wrapper around getBestTest for Hits from findOverlaps,
# when windows are overlapped with regions.
#
# written by Aaron Lun
# created 25 March 2015
# last modified 26 March 2015
{
	.overlapStats(olap, tab, o.weight=o.weight, i.weight=i.weight, type="best", ...)
}

#' @export
empiricalOverlaps <- function(olap, tab, o.weight=NULL, i.weight=NULL, ...) 
# Wrapper around empiricalFDR for Hits from findOverlaps,
# when windows are overlapped with regions
#
# written by Aaron Lun
# created 7 January 2017
{
    .overlapStats(olap, tab, o.weight=o.weight, i.weight=i.weight, type="empirical", ...)
}

#' @export
mixedOverlaps <- function(olap, tab, o.weight=NULL, i.weight=NULL, ...) 
# Wrapper around mixedClusters for Hits from findOverlaps,
# when windows are overlapped with regions
#
# written by Aaron Lun
# created 7 January 2017
{
    .overlapStats(olap, tab, o.weight=o.weight, i.weight=i.weight, type="mixed", ...)
}

#' @export
#' @importFrom S4Vectors queryHits subjectHits 
summitOverlaps <- function(olap, region.best, o.summit=NULL, i.summit=NULL)
# Wrapper around upweightSummits for Hits from findOverlaps.
#
# written by Aaron Lun
# created 25 March 2015
# last modified 26 March 2015
{
	region.dex <- queryHits(olap)
	win.dex <- subjectHits(olap)

	if (!missing(region.best)) { 
		summit.dex <- region.best[region.dex]
		summits <- !is.na(summit.dex) & win.dex==summit.dex

	} else if (!is.null(o.summit)) {
		if (is.integer(o.summit)) { 
			out <- logical(length(olap))
			out[o.summit] <- TRUE
			o.summit <- out
		} else {
			stopifnot(length(o.summit)==length(olap))
		}	
		summits <- o.summit

 	} else if (!is.null(i.summit)) { 	
		if (is.integer(i.summit)) { 
			out <- logical(max(win.dex, i.summit))
			out[i.summit] <- TRUE
			i.summit <- out
		}
		summits <- i.summit[win.dex]

	} else {
		stop("either region.best, i.summit or o.summit must be specified")
	}

	upweightSummit(region.dex, summits)
}



