import { router } from "@inertiajs/react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Bell, Check, CheckCheck, FolderKanban, MessageSquare, AlertCircle } from "lucide-react"
import { formatDistanceToNow } from "date-fns"
import { useBreadcrumbContext } from "@/contexts/breadcrumb-context"
import { useEffect } from "react"
import { cn } from "@/lib/utils"

interface NotificationType {
    id: number
    name: string
    category: string
}

interface Notification {
    id: number
    title: string
    body: string
    data: any
    read_at: string | null
    created_at: string
    notification_type: NotificationType
}

interface Props {
    notifications: Notification[]
    unread_count: number
}

const categoryIcons = {
    project: <FolderKanban className="h-4 w-4" />,
    team: <MessageSquare className="h-4 w-4" />,
    system: <AlertCircle className="h-4 w-4" />,
}

const categoryColors = {
    project: "bg-blue-100 text-blue-800",
    team: "bg-green-100 text-green-800",
    system: "bg-red-100 text-red-800",
}

export default function NotificationCenter({ notifications, unread_count }: Props) {
    const { setBreadcrumbs } = useBreadcrumbContext()
    
    useEffect(() => {
        setBreadcrumbs([
            { label: "Notification Center" }
        ])
    }, [setBreadcrumbs])

    const handleMarkRead = (notificationId: number) => {
        router.patch(`/notification_center/${notificationId}/mark_read`, {}, {
            preserveScroll: true,
        })
    }

    const handleMarkAllRead = () => {
        router.patch('/notification_center/mark_all_read', {}, {
            preserveScroll: true,
        })
    }

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-3xl font-bold flex items-center gap-2">
                        <Bell className="h-8 w-8" />
                        Notification Center
                    </h1>
                    <p className="text-muted-foreground mt-2">
                        {unread_count > 0 
                            ? `You have ${unread_count} unread notification${unread_count === 1 ? '' : 's'}`
                            : 'All caught up!'
                        }
                    </p>
                </div>
                
                {unread_count > 0 && (
                    <Button 
                        variant="outline" 
                        onClick={handleMarkAllRead}
                        className="flex items-center gap-2"
                    >
                        <CheckCheck className="h-4 w-4" />
                        Mark all as read
                    </Button>
                )}
            </div>

            <Card>
                <CardHeader>
                    <CardTitle>Recent Notifications</CardTitle>
                    <CardDescription>
                        Your latest updates and alerts
                    </CardDescription>
                </CardHeader>
                <CardContent className="p-0">
                    <ScrollArea className="h-[600px]">
                        {notifications.length === 0 ? (
                            <div className="p-6 text-center text-muted-foreground">
                                <Bell className="h-12 w-12 mx-auto mb-4 opacity-20" />
                                <p>No notifications yet</p>
                                <p className="text-sm mt-2">
                                    When you receive notifications, they'll appear here
                                </p>
                            </div>
                        ) : (
                            <div className="divide-y">
                                {notifications.map((notification) => (
                                    <div
                                        key={notification.id}
                                        className={cn(
                                            "p-4 hover:bg-muted/50 transition-colors",
                                            !notification.read_at && "bg-blue-50/50"
                                        )}
                                    >
                                        <div className="flex justify-between items-start gap-4">
                                            <div className="flex-1 space-y-2">
                                                <div className="flex items-center gap-2">
                                                    <Badge 
                                                        variant="secondary"
                                                        className={cn(
                                                            "text-xs",
                                                            categoryColors[notification.notification_type.category as keyof typeof categoryColors]
                                                        )}
                                                    >
                                                        <span className="mr-1">
                                                            {categoryIcons[notification.notification_type.category as keyof typeof categoryIcons]}
                                                        </span>
                                                        {notification.notification_type.name}
                                                    </Badge>
                                                    {!notification.read_at && (
                                                        <Badge variant="default" className="text-xs">
                                                            New
                                                        </Badge>
                                                    )}
                                                </div>
                                                
                                                <h3 className={cn(
                                                    "font-semibold",
                                                    notification.read_at && "text-muted-foreground"
                                                )}>
                                                    {notification.title}
                                                </h3>
                                                
                                                <p className={cn(
                                                    "text-sm",
                                                    notification.read_at 
                                                        ? "text-muted-foreground" 
                                                        : "text-foreground"
                                                )}>
                                                    {notification.body}
                                                </p>
                                                
                                                <p className="text-xs text-muted-foreground">
                                                    {formatDistanceToNow(new Date(notification.created_at), { addSuffix: true })}
                                                </p>
                                            </div>
                                            
                                            {!notification.read_at && (
                                                <Button
                                                    size="sm"
                                                    variant="ghost"
                                                    onClick={() => handleMarkRead(notification.id)}
                                                    className="shrink-0"
                                                >
                                                    <Check className="h-4 w-4" />
                                                    <span className="sr-only">Mark as read</span>
                                                </Button>
                                            )}
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )}
                    </ScrollArea>
                </CardContent>
            </Card>
        </div>
    )
}