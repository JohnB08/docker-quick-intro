FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /api

COPY ["api/api.csproj", "api/"]
RUN dotnet restore "api/api.csproj"

COPY api/ api/
WORKDIR /api/api
RUN dotnet build "api.csproj" -c Release -o /out

FROM build AS publish
RUN dotnet publish "api.csproj" -c Release -o /publish


FROM mcr.microsoft.com/dotnet/aspnet:8.0
COPY --from=publish /publish .

EXPOSE 8080

ENTRYPOINT ["dotnet", "api.dll"]