#!/bin/bash

# Set the target platforms
platforms=("darwin/amd64" "darwin/arm64" "linux/amd64" "linux/arm64")


# Set the output directory to the current directory
output_dir="./dist"
version="${VERSION:-1.11.0}"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"


go get github.com/arthurnn/twirp-ruby/protoc-gen-twirp_ruby@v$version
# Compile and install the plugin for each platform
for platform in "${platforms[@]}"; do
    IFS='/' read -ra parts <<< "$platform"
    os="${parts[0]}"
    arch="${parts[1]}"

    echo "Compiling protoc-gen-twirp_ruby for $os/$arch..."

    # Set the appropriate environment variables for cross-compilation
    export GOOS="$os"
    export GOARCH="$arch"

    # Compile the plugin
    go build -o "$output_dir/protoc-gen-twirp_ruby" github.com/arthurnn/twirp-ruby/protoc-gen-twirp_ruby
    chmod u+x "$output_dir/protoc-gen-twirp_ruby"

    echo "Compiled protoc-gen-twirp_ruby for $os/$arch and placed it in $output_dir"

    # Archive the compiled executable
    tar_name="protoc-gen-twirp_ruby-$version-$os-$arch.tar.gz"
    tar -czvf "$output_dir/$tar_name" -C "$output_dir" "protoc-gen-twirp_ruby"

    echo "Archived protoc-gen-twirp_ruby to $output_dir/$tar_name"

    # Remove the executable after archiving
    rm "$output_dir/protoc-gen-twirp_ruby"

    echo "Removed the executable $output_dir/protoc-gen-twirp_ruby"
done

echo "All protoc-gen-twirp_ruby binaries have been compiled and placed in the current directory."
echo "You can now use the compiled binaries without modifying the PATH environment variable."
