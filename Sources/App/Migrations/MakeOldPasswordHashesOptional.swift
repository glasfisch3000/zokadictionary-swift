import Fluent
import FluentPostgresDriver

struct MakeOldPasswordHashesOptional: AsyncMigration {
    func prepare(on database: any Database) async throws {
		try await (database as! SQLDatabase)
			.raw("""
   ALTER TABLE "users"
   ALTER COLUMN "password_hash_argon2" SET NOT NULL,
   ALTER COLUMN "password" DROP NOT NULL,
   ALTER COLUMN "salt" DROP NOT NULL;
   """)
			.run()
    }
    
    func revert(on database: any Database) async throws {
		try await (database as! SQLDatabase)
			.raw("""
   ALTER TABLE "users"
   ALTER COLUMN "password_hash_argon2" DROP NOT NULL,
   ALTER COLUMN "password" SET NOT NULL,
   ALTER COLUMN "salt" SET NOT NULL;
   """)
			.run()
    }
}
