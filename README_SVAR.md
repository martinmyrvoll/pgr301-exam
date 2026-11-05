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