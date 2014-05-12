/* These two settings result in a 2x to 50x speedup for SQLite
 * If you are concerned, you can use synchronous = NORMAL
 * Remember that btrfs does not actually obey fsync so this has less of an
 * impact with btrfs than others and it will seem pretty fast either way.
 */
PRAGMA journal_mode = WAL;
PRAGMA synchronous = OFF;
PRAGMA foreign_keys = ON;

/*
 * meta and content are separate because the content is very large and makes
 * routine changes slower otherwise.
 */
CREATE TABLE meta (
    id INTEGER PRIMARY KEY,
    title TEXT,
    source TEXT,
    reference TEXT,
    pageviews INTEGER
);

CREATE TABLE content (
    id INTEGER PRIMARY KEY,
    text TEXT,
    FOREIGN KEY(id) REFERENCES meta(id)
);

CREATE INDEX meta_source ON meta(source);
CREATE INDEX meta_title ON meta(title);

CREATE TABLE redirects (
    target_id INTEGER,
    source_title TEXT,
    FOREIGN KEY(target_id) REFERENCES meta(id)
);
CREATE INDEX redirects_id ON redirects(target_id);

-- Used for an experimental scorer. (PhraseTokens)
-- Should it be moved to another DB?
CREATE TABLE relate_words(
    id INTEGER PRIMARY KEY,
    name TEXT UNIQUE,
    count INTEGER
);
CREATE TABLE relate_links(
    id INTEGER PRIMARY KEY,
    source INTEGER,
    dest INTEGER,
    count INTEGER,
    FOREIGN KEY(source) REFERENCES relate_words(id),
    FOREIGN KEY(dest) REFERENCES relate_words(id),
    UNIQUE(source, dest)
);
