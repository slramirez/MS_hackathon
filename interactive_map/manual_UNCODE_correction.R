#Load in UN codes
un_codes = read_csv("../data/GapMinder_Raw_CSVs/UNCTRY_CODES.csv") %>% select(1,2)
names(un_codes) = tolower(names(un_codes))

# Identify missing codes
missing_ctry = df %>% select(country, unctry) %>% distinct() %>% filter(unctry == 0)

# Corrections
missing_ctry[1,"unctry"] = un_codes[str_detect(un_codes$ctry, pattern="Verde"),"unctry"]
missing_ctry[2,"unctry"] = un_codes[str_detect(un_codes$ctry, pattern="Congo"),"unctry"][2,]
missing_ctry[3,"unctry"] = un_codes[str_detect(un_codes$ctry, pattern="Congo"),"unctry"][1,]
missing_ctry[4,"unctry"] = un_codes[str_detect(un_codes$ctry, pattern="Ivoire"),"unctry"]
missing_ctry[5,"unctry"] = un_codes[str_detect(un_codes$ctry, pattern="Czech"),"unctry"]
missing_ctry[6,"unctry"] = un_codes[str_detect(un_codes$ctry, pattern="Kyrgyz"),"unctry"]
missing_ctry[7,"unctry"] = un_codes[str_detect(un_codes$ctry, pattern="Macedonia"),"unctry"]
missing_ctry[8,"unctry"] = un_codes[str_detect(un_codes$ctry, pattern="Micronesia"),"unctry"]
missing_ctry[9,"unctry"] = un_codes[str_detect(un_codes$ctry, pattern="Korea"),"unctry"][1,]
missing_ctry[10,"unctry"] = un_codes[str_detect(un_codes$ctry, pattern="Slovak"),"unctry"]
missing_ctry[11,"unctry"] = un_codes[str_detect(un_codes$ctry, pattern="Korea"),"unctry"][2,]
missing_ctry[12,"unctry"] = un_codes[str_detect(un_codes$ctry, pattern="Nevis"),"unctry"]
missing_ctry[13,"unctry"] = un_codes[str_detect(un_codes$ctry, pattern="Lucia"),"unctry"]
missing_ctry[14,"unctry"] = un_codes[str_detect(un_codes$ctry, pattern="Vincent"),"unctry"]
missing_ctry[15,"unctry"] = un_codes[str_detect(un_codes$ctry, pattern="Eswati"),"unctry"]
missing_ctry[16,"unctry"] = un_codes[str_detect(un_codes$ctry, pattern="Viet"),"unctry"]

# Change the UN number heading.
names(missing_ctry)[2] = "new_unctry"
# Join the missing values to the original df.
df = left_join(df, missing_ctry)
# Make any NA values in the new UN column.
df[is.na(df$new_unctry),"new_unctry"] = 0
# Update the old UN column by adding it to the new UN.
df$unctry = df$unctry + df$new_unctry
# Remove the unused column
df = df %>% select(-new_unctry)

df %>% select(country,unctry) %>% distinct() %>% rename(CTRY=country, UNCTRY = unctry) %>% 
write_csv(path = "../data/GapMinder_Raw_CSVs/UNCTRY_CODES_GapMinderNames.csv")
