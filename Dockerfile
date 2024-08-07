FROM ubuntu:20.04

# Set noninteractive installation
ENV DEBIAN_FRONTEND=noninteractive

# Set timezone
RUN apt-get update && apt-get install -y tzdata
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# Update package lists and install necessary packages
RUN apt-get update && apt-get install -y openssh-server python3 software-properties-common git && \
    apt-add-repository --yes --update ppa:ansible/ansible && \
    apt-get install -y ansible

# Create the directory for SSH runtime files
RUN mkdir /var/run/sshd

# Set the root password
RUN echo 'root:password' | chpasswd

# Allow root login via SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Expose port 22 for SSH
EXPOSE 22

# Copy the local script to the home directory in the container
COPY config-init /root/config-init

# Make the script executable
RUN chmod +x /root/config-init

# Run the script from the home directory
RUN /root/config-init

# Start the SSH daemon
CMD ["/usr/sbin/sshd", "-D"]

