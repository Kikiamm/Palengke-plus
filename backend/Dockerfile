# Use an official Python runtime as a parent image
FROM python:3.9

# Set the working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Make start.sh executable
RUN chmod +x /app/backend/start.sh

# Expose the port the app runs on
EXPOSE 8000

# Run the application
CMD ["bash", "backend/start.sh"]