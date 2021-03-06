\name{scaledAverage}
\alias{scaledAverage}

\title{Scaled average abundance}
\description{Compute the scaled average abundance for each feature.}

\usage{
scaledAverage(y, scale=1, prior.count=NULL, dispersion=NULL, assay.id="counts")
}

\arguments{
\item{y}{A SummarizedExperiment object containing a count matrix.
Previous versions accepted a \code{DGEList} object, this is now deprecated.}
\item{scale}{a numeric scalar vector indicating the magnitude with which each abundance is to be downscaled}
\item{prior.count}{a numeric scalar specifying the prior count to add}
\item{dispersion}{a numeric scalar or vector specifying the dispersion for GLM fitting.}
\item{assay.id}{A string or integer scalar indicating which assay of \code{y} contains the counts.}
}

\details{
This function computes the average abundance of each feature in \code{y}, and downscales it according to \code{scale}.
For example, if \code{scale=2}, the average count is halved, i.e., the returned abundances are decreased by 1 (as they are log2-transformed values).
The aim is to set \code{scale} based on the relative width of regions, to allow abundances to be compared between regions of different size.
Widths can be obtained using the \code{\link{getWidths}} function.

This function mimics the behaviour of \code{\link{aveLogCPM}} but handles the \code{prior.count} with some subtlety.
Specifically, it scales up the prior count by \code{scale} before adding it to the counts.
This ensures that the \dQuote{effective} prior is the same after the abundance is scaled down.
Otherwise, the use of the same prior would incorrectly result in a smaller abundance for larger regions, regardless of the read density.

An additional difference from \code{\link{aveLogCPM}} is that the prior count is \emph{not} scaled up before being added to the library sizes/offsets.
(See \code{\link{addPriorCount}} for more details.)
This ensures that the modified offsets do not depend on \code{scale}, which allows abundances to be compared between regions of differing size.
Otherwise, larger regions with greater \code{scale} would always have (slightly) larger modified offsets and lower abundances than appropriate.

Note that the adjustment for width assumes that reads are uniformly distributed throughout each region.
This is reasonable for most background regions, but may not be for enriched regions.
When the distribution is highly heterogeneous, the downscaled abundance of a large region will not be an accurate representation of the abundance of the smaller regions nested within.

% It's advisable to set scale>1 for the larger region, and make it equal to 1 for the smaller region.
% This means that a non-tiny prior will actually be added.
% While you will get massive priors for the larger region, keep in mind that this is scaled down again.
% So, if you interpret it from the POV of the abundances after scaling, the added prior is just prior.count.
% You need this to avoid getting crazy fold changes in the comparisons.

For consistency, the \code{prior.count} is set to the default value of \code{\link{aveLogCPM.DGEList}}, if it is not otherwise specified.
If a non-default value is used, make sure that it is the same for all calls to \code{scaledAverage}.
This ensures that comparisons between the returned values are valid.
}

\value{
A numeric vector of scaled abundances, with one entry for each row of \code{y}.
}

\seealso{
\code{\link{getWidths}},
\code{\link{aveLogCPM}},
\code{\link{addPriorCount}}
}

\author{
Aaron Lun
}

\examples{
bamFiles <- system.file("exdata", c("rep1.bam", "rep2.bam"), package="csaw")
size1 <- 50
data1 <- windowCounts(bamFiles, width=size1, filter=1)
size2 <- 500
data2 <- windowCounts(bamFiles, width=size2, filter=1)

# Adjusting by `scale`, based on median sizes.
head(scaledAverage(data1))
relative <- median(getWidths(data2))/median(getWidths(data1))
head(scaledAverage(data2, scale=relative))

# Need to make sure the same prior is used, if non-default.
pc <- 5
head(scaledAverage(data1, prior.count=pc))
head(scaledAverage(data2, scale=relative, prior.count=pc))

# Different way to compute sizes, for 1-to-1 relations.
data3 <- regionCounts(bamFiles, regions=resize(rowRanges(data1),   
    fix="center", width=size2))
head(scaledAverage(data1))
relative.2 <- getWidths(data1)/getWidths(data2)
head(scaledAverage(data3), scale=relative.2)
}

\keyword{filtering}
