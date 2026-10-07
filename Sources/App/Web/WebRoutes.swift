import Vapor

struct WebRoutes: RouteCollection {
	func boot(routes: any RoutesBuilder) throws {
		routes.group("login") {
			$0.get(use: getLogin(req:))
			$0.post(use: postLogin(req:))
		}
		
		routes.group("logout") {
			$0.get(use: getLogout(req:))
			$0.post(use: postLogout(req:))
		}
		
		routes.get(use: index(req:))
		routes.get("words", use: getSearch(req:))
		
		routes.group("new-item") {
			$0.get(use: getNewItem(req:))
			$0.post(use: postNewItem(req:))
		}
		
		routes.group("change-username") {
			$0.get(use: getChangeUsername(req:))
			$0.post(use: postChangeUsername(req:))
		}
		
		routes.group("change-password") {
			$0.get(use: getChangePassword(req:))
			$0.post(use: postChangePassword(req:))
		}
		
		routes.group("words", ":wordID") { word in
			word.group("edit") {
				$0.get(use: getEditItem(req:))
				$0.post(use: postEditItem(req:))
			}
			
			word.group("delete") {
				$0.get(use: getDeleteItem(req:))
				$0.post(use: postDeleteItem(req:))
			}
			
			word.group("restore") {
				$0.get(use: getRestoreItem(req:))
				$0.post(use: postRestoreItem(req:))
			}
			
			word.group("delete-for-real-no-cap") {
				$0.get(use: getPermanentlyDeleteItem(req:))
				$0.post(use: postPermanentlyDeleteItem(req:))
			}
		}
		
		routes.grouped(User.guardMiddleware(throwing: AuthError.missingLogin)).group("users") { users in
			users.get(use: getManageUsers(req:))
			
			users.group("new-user") {
				$0.get(use: getNewUser(req:))
				$0.post(use: postNewUser(req:))
			}
			
			users.group(":userID") { user in
				user.group("delete") {
					$0.get(use: getDeleteUser(req:))
					$0.post(use: postDeleteUser(req:))
				}
			}
		}
	}
}
