\name{clusterWindows}
\alias{clusterWindows}

\title{Cluster DB windows into clusters}

\description{Clusters significant windows into clusters while controlling the cluster-level FDR.}

\usage{
clusterWindows(regions, tab, target, pval.col=NULL, fc.col=NA, tol, 
    ..., weight=NULL, grid.length=21, iterations=4)
}

\arguments{
	\item{regions}{A GRanges or RangedSummarizedExperiment object containing window coordinates.}
    \item{tab}{A dataframe of results with a \code{PValue} field for each window.}
    \item{target}{A numeric scalar indicating the desired cluster-level FDR.}
    \item{pval.col}{A string or integer scalar specifying the column of \code{tab} with the p-values.}
    \item{fc.col}{A string or integer scalar specifying the column of \code{tab} with the log-fold changes.}
	\item{tol, ...}{Arguments to be passed to \code{\link{mergeWindows}}.}
    \item{weight, grid.length, iterations}{Arguments to be passed to \code{\link{controlClusterFDR}}.}
}

\value{
A named list similar to that reported by \code{\link{mergeWindows}} with an ID vector in \code{id} and region coordinates of each cluster in \code{region}.
Non-significant windows are marked with \code{NA} values in \code{ids}.
An additional element \code{FDR} is also included, representing the estimate of the cluster-level FDR for the returned regions.
}

\details{
Windows are identified as DB based on the adjusted p-values in \code{tab}.
Only these DB windows are then used directly for clustering via \code{\link{mergeWindows}}.
This identifies DB regions consisting solely of DB windows.
If \code{tol} is not specified, it is set to 100 bp by default and a warning is raised.
If \code{fc.col} is used to specify the column of log-fold changes, clusters are formed according to the sign of the log-fold change in \code{\link{mergeWindows}}.

DB-based clustering is obviously not blind to the DB status, so standard methods for FDR control are not valid.
Instead, post-hoc control of the cluster-level FDR is applied by using \code{\link{controlClusterFDR}}.
This aims to control the cluster-level FDR at \code{target} (which is set to 0.05 if not specified).
The aim is to provide some interpretable results when DB-blind clustering is not appropriate, e.g., for diffuse marks involving long stretches of the genome.
Reporting each marked stretch in its entirety would be cumbersome, so this method allows the DB subintervals to be identified directly.
}

\examples{
set.seed(10)
x <- round(runif(100, 100, 1000))
gr <- GRanges("chrA", IRanges(x, x+5))
tab <- data.frame(PValue=rbeta(length(x), 1, 50), logFC=rnorm(length(x)))

clusterWindows(gr, tab, target=0.05, tol=10)
clusterWindows(gr, tab, target=0.05, tol=10, fc.col="logFC")
}

\seealso{
\code{\link{mergeWindows}},
\code{\link{controlClusterFDR}}
}

\author{Aaron Lun}

\keyword{clustering}
