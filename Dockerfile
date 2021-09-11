FROM rocker/r-ver:4.0.2

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
	make \
	libsodium-dev \
	libicu-dev \
	libcurl4-openssl-dev \
	libssl-dev

# Using rocker to install these packages doesn't provide the latest versions
# Instead, we'll use the precompiled binaries kindly provided by RStudio
# Package versions pinned to 2020-10-01
ENV CRAN_REPO https://packagemanager.rstudio.com/all/__linux__/focal/338
RUN Rscript -e 'install.packages(c("plumber", "promises", "future"), repos = c("CRAN" = Sys.getenv("CRAN_REPO")))'

# Create a non-root plumber user to run the API, along with a new home directory
RUN groupadd -r plumber && useradd --no-log-init -r -g plumber plumber

ADD plumber.R /home/plumber/plumber.R
ADD entrypoint.R /home/plumber/entrypoint.R

EXPOSE 8000

WORKDIR /home/plumber
USER plumber
CMD Rscript entrypoint.R
