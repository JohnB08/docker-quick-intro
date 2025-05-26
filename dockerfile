
# Docker filen her er vårt "blueprint" til containeren som skal kjøre vår applikasjon.

# Dette blir også kalt et Bilde / Image

# Det består av Cacheable lag av instruksjoner.
# Hver instruksjon representerer et lag. 
# Og for hvert lag blir det også lagret en hash som representerer laget.
# Det gjør det mulig å bruke cachede biter av imaget isteden for å bygge hele containeren opp fra grunn,
# når bildet blir brukt for å lage en container. 


# Disse bildene blir ofte laget basert på andre "basebilder".
# I dette tilfelle bruker vi et basebilde fra microsoft, som inneholder dotnet 8.0 sdk for å bygge vårt prosjekt
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

# Etter vi har lastet ned basebilde fra microsoft, forteller vi docker å lage et Working Directory /api.
WORKDIR /api

# Vi kopierer så vår csproj fil, inn i Docker containeren sin api mappe.
# Før vi kjører dotnet restore via csproj filen vår. 
# Legg merke til at dette er fire separate lag, hvert lag kan gjennbrukes fra en cache, om ikke et annet lag / dependenciene til laget er oppdatert.
# Vi kan tvinge docker til å bygge hele filen på nytt via --no-cache flagget. 
COPY ["api/api.csproj", "api/"]
RUN dotnet restore "api/api.csproj"

# her kopierer vi resterende applikasjonen vår, før vi bygger prosjektet vårt, og putter builden i /out
COPY api/ api/
WORKDIR /api/api
RUN dotnet build "api.csproj" -c Release -o /out


# Etter vi har bygget prosjektet, publiserer vi prosjektet til en ferdig dll via dotnet publish.
# Vi setter dll i en /publish mappe i workdir
FROM build AS publish
RUN dotnet publish "api.csproj" -c Release -o /publish

# Docker er et isolert environment, men ikke en komplett VM, så det kan være greit å lage en intern
# linux bruker som "eier" prosjektet ditt, men ellers ikke har tilgang til andre deler av prosjektet / environmentet (også kalt root access)
RUN addgroup --gid 1001 --system dotnet && \
    adduser --uid 1001 --system --gid 1001 --shell /bin/false dotnet

# Vi lager så et siste "runtime" layer som styrer selve kjøringen av prosjektet vårt.
FROM mcr.microsoft.com/dotnet/aspnet:8.0
# Her kopiererer vi alt fra publish til workdir, og passer på at workdir er eid av dotnet brukeren vi laget ovenfor.
COPY --from=publish --chown=dotnet:dotnet /publish .

# Vi skifter så bruker til dotnet
USER dotnet

# Her forteller vi hvilken intern port på denne containeren sitt netverk applikasjonen kjører på
# Vi publiserer ikke porten her, og må fremdeles mappe den til en faktisk fysisk port på server / maskin hvis vi vil connecte til den
# via localhost.
EXPOSE 8080

# Og definerer et entrypoint til bildet vårt (aka hvordan skal bilde starte containeren etter alle lagene er bygget og validert.)
ENTRYPOINT ["dotnet", "api.dll"]