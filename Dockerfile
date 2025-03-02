# Build the manager binary
FROM golang:1.17 as builder

WORKDIR /workspace

#ENV http_proxy=http://defraprx-fihelprx.glb.nsn-net.net:8080
#ENV https_proxy=http://defraprx-fihelprx.glb.nsn-net.net:8080
#ENV HTTP_PROXY=http://defraprx-fihelprx.glb.nsn-net.net:8080
#ENV HTTPS_PROXY=http://defraprx-fihelprx.glb.nsn-net.net:8080
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum

# fix for CVE 
#RUN go get golang.org/x/crypto

# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download


# Copy the go source
COPY main.go main.go
COPY api/ api/
COPY controllers/ controllers/
COPY issuers/ issuers/
COPY adcs/ adcs/
COPY healthcheck/ healthcheck/

# Build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on go build -a -o manager main.go

# Use distroless as minimal base image to package the manager binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM gcr.io/distroless/static:nonroot 
WORKDIR /
COPY --from=builder /workspace/manager .
USER nonroot:nonroot

ENTRYPOINT ["/manager"]
