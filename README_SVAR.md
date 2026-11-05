Kandidatnr: 17

## Oppgave 1A

### Kjøre containeren
```bash
docker build -t wishifai .
cp .env.example .env # AWS keys og bucket name her
docker run --rm -p 9999:8080 --env-file .env wishifai
```
Test: `curl -F "image=@samples/sample_image.png" http://localhost:9999/api/analyze`

### Valg
**Multi-stage build:** Første steg bruker jeg et Maven JDK 21-image til å bygge JAR-filen.
Andre steg starter jeg fra et clean JRE 21-image og kopierer kun inn den ferdige JAR-en.
Maven, JDK og kildekoden blir dermed ikke med i det siste imaget. Det gir et mindre image og raskere deploy.

**Caching av dependencies:** `pom.xml` kopieres og avheninghetene lastes ned før kildekoden kopieres inn.
Endringer i Java-koden gjør at ikke alle avheninghetene lastes ned pånytt og builden går kjappere.

**Ikke-root bruker:** Applikasjonen kjører som egen bruker (`spring`) i stedet for root.
Hvis en annen skulle klare å utnytte en sårbarhet i applikasjonen, får de da begrensede rettigheter i containeren.

**Hemmeligheter:** AWS-nøkler bygges ikke inn i imaget, men sendes inn som miljøvariabler ved oppstart via
`--env-file`. `.env` ligger i `.gitignore`, og `.env.example` viser hvilke variabler som må brukes.

## Oppgave 1B

**Workflow:** `.github/workflows/ci.yml`
**Grønn kjøring:** TBD

Workflowen kjører kun ved push til `main`. Den bygger Docker-imaget og pusher det til ECR repoet som jeg laget,
`wishifai-17`. AWS-nøklene ligger inne i Github under actions secrets. 

### Tagging-strategi
Hvert image får to tagger: den korte commit-SHA-en f. eks. `a1b2c3d` og `latest`.

**Commit-SHA:** Kobler hver image til nøyaktig én commit. Da kan man alltid se hvilken kode som kjører i ECS og finne
igjen commiten hvis noe skulle skjære seg. SHA-en er unik, så et gammelt image vil aldri bli overskrevet.
Rollback gjøres ved å deploye en eldre tag som virket.

**`latest`:** Bare for å gjøre det enkelt å hente nyeste versjon lokalt. Den brukes ikke til deploy, fordi den endrer
seg hele tiden og ikke sier noe om hvilken versjon det er.

Jeg valgte SHA fremfor klassisk verjsonering (f. eks. `1.0.2`), fordi det ikke krever noe manuelt arbeid.
Hver push til `main` får automatisk en unik og sporbar tag.