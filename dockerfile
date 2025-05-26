FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /api

COPY ["api/api.csproj", "api/"]
RUN dotnet restore "api/api.csproj"

COPY api/ api/
WORKDIR /api/api
RUN dotnet build "api.csproj" -c Release -o /out

FROM build AS publish
RUN dotnet publish "api.csproj" -c Release -o /publish

RUN addgroup --gid 1001 --system dotnet && \
    adduser --uid 1001 --system --gid 1001 --shel /bin/false dotnet

FROM mcr.microsoft.com/dotnet/aspnet:8.0
COPY --from=publish --chown=dotnet:dotnet /publish .

USER dotnet

EXPOSE 8080

ENTRYPOINT ["dotnet", "api.dll"]