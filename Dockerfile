FROM registry.access.redhat.com/ubi8/dotnet-31-runtime:3.1 AS base
WORKDIR /app
EXPOSE 80

FROM registry.access.redhat.com/ubi8/dotnet-31:3.1 AS build
WORKDIR /w

COPY ./sampledb31.sln ./NuGet.config ./docker-compose.dcproj ./version.props ./

COPY build build/

COPY src/*/*.csproj ./
RUN for file in $(ls *.csproj); do mkdir -p src/${file%.*}/ && mv $file src/${file%.*}/; done

COPY test/*/*.csproj ./
RUN for file in $(ls *.csproj); do mkdir -p test/${file%.*}/ && mv $file test/${file%.*}/; done

RUN dotnet restore ./sampledb31.sln

COPY ./src ./src
COPY ./test ./test

RUN dotnet build ./Solution.sln -c Release -o /b/build -v Normal

FROM build AS publish
RUN dotnet publish ./src/Project/sampledb31.csproj -c Release -o /b/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /b/publish .
ENTRYPOINT ["dotnet", "sampledb31.dll"]
