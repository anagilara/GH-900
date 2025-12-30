# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy project file and restore dependencies
COPY ["myGHrepo.csproj", "./"]
RUN dotnet restore "myGHrepo.csproj"

# Copy the rest of the application code
COPY . .

# Build the application
RUN dotnet build "myGHrepo.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "myGHrepo.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

# Install curl for health checks
USER root
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Copy published application from publish stage
COPY --from=publish --chown=appuser:appuser /app/publish .

# Expose port
EXPOSE 8080

# Set environment variables
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

# Run the application
ENTRYPOINT ["dotnet", "myGHrepo.dll"]
