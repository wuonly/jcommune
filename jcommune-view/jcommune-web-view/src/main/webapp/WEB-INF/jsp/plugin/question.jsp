<%--

    Copyright (C) 2011  JTalks.org Team
    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.
    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.
    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="jtalks" uri="http://www.jtalks.org/tags" %>
<%@ taglib prefix="security" uri="http://www.springframework.org/security/tags" %>
<jsp:useBean id="question" type="org.jtalks.jcommune.model.entity.Topic" scope="request"/>
<head>
  <meta name="description" content="<c:out value="${question.title}"/>">
  <title>
    <c:out value="${cmpTitlePrefix}"/>
    <c:out value="${question.title}"/>
  </title>
</head>
<body>

<c:set var="authenticated" value="${false}"/>
<div class="container">
<%-- Topic header --%>
<div id="branch-header">
  <h1>
    <a class="invisible-link" href="${pageContext.request.contextPath}/topics/${question.id}">
      <c:out value="${question.title}"/>
    </a>
  </h1>

  <div id="right-block">
    <sec:authorize access="isAuthenticated()">
           <span id="subscribe">
               <i class="icon-star"></i>
               <c:choose>
                 <c:when test="${subscribed}">
                   <a id="subscription" class="button top_button"
                      href="${pageContext.request.contextPath}/topics/${question.id}/unsubscribe"
                      title="<spring:message code="label.unsubscribe.tooltip"/>">
                     <spring:message code="label.unsubscribe"/>
                   </a>
                 </c:when>
                 <c:otherwise>
                   <a id="subscription" class="button top_button"
                      href="${pageContext.request.contextPath}/topics/${question.id}/subscribe"
                      title='<spring:message code="label.subscribe.tooltip"/>'>
                     <spring:message code="label.subscribe"/>
                   </a>
                 </c:otherwise>
               </c:choose>
           </span>
      <c:set var="authenticated" value="${true}"/>
    </sec:authorize>
  </div>
  <span class='inline-block'></span>
</div>
<%-- END OF Topic header --%>

<%--<jtalks:breadcrumb breadcrumbList="${breadcrumbList}"/>--%>

<%-- Upper pagination --%>
<div class="row-fluid upper-pagination forum-pagination-container">
  <div class="span3">
    <%--<jtalks:topicControls topic="${question}"/>--%>
    &nbsp; <%-- For proper pagination layout without buttons--%>
  </div>

  <%-- Pagination --%>
  <div class="span9">
    <div class="pagination pull-right forum-pagination">
      <ul>
        <jtalks:pagination uri="${topicId}" page="${postsPage}"/>
      </ul>
    </div>
  </div>
  <%-- END OF Pagination --%>

</div>
<%-- END OF Upper pagination --%>

<div>
<%-- List of posts. --%>
<c:forEach var="post" items="${postsPage.content}" varStatus="i">
<%-- Post --%>
<c:set var="isFirstPost" value="false"/>
<c:if test="${postsPage.number == 1 && i.index == 0}">
  <c:set var="isFirstPost" value="true"/>
</c:if>

<c:set var="postClass" value=""/>
<c:if test="${isFirstPost}">
  <c:set var="postClass" value="script-first-post"/>
</c:if>

<div class="post ${postClass}">
<div class="anchor">
  <a id="${post.id}">anchor</a>
</div>
<table class="table table-row table-bordered table-condensed">
  <tr class="post-header">
    <td class="post-date">
      <i class="icon-calendar"></i>
      <jtalks:format value="${post.creationDate}"/>
    </td>
    <td class="top-buttons">
      &nbsp;
      <div class="btn-toolbar post-btn-toolbar">
        <div class="btn-group">

          <c:choose>
            <c:when test="${isFirstPost}">
              <%-- first post - urls to delete & edit topic --%>
              <c:set var="delete_url"
                     value="${pageContext.request.contextPath}/topics/${question.id}"/>
              <c:set var="edit_url"
                     value="${pageContext.request.contextPath}/topics/${question.id}/edit"/>
              <c:set var="confirm_message" value="label.deleteTopicConfirmation"/>
            </c:when>
            <c:otherwise>
              <%-- url to delete & edit post --%>
              <c:set var="delete_url"
                     value="${pageContext.request.contextPath}/posts/${post.id}"/>
              <c:set var="edit_url"
                     value="${pageContext.request.contextPath}/posts/${post.id}/edit"/>
              <c:set var="confirm_message" value="label.deletePostConfirmation"/>
            </c:otherwise>
          </c:choose>
          <sec:authorize access="isAuthenticated()">
            <sec:authentication property="principal.id" var="userId"/>
            <%--Edit post button start --%>
            <c:set var="isEditButtonAvailable" value="false"/>
            <%--  An ability to edit posts for author of this posts --%>
            <c:if test='${userId == post.userCreated.id}'>
              <c:set var="isEditButtonAvailable" value="true"/>
            </c:if>
            <%--  An ability to edit posts for administrators and branch moderators --%>
            <c:if test='${userId != post.userCreated.id}'>
              <c:set var="isEditButtonAvailable" value="true"/>
            </c:if>
            <c:set var="hasCloseTopicPermission" value="true"/>

            <c:if test="${isEditButtonAvailable}">
              <a href="${edit_url}" data-rel="${question.branch.id}"
                 class="edit_button btn btn-mini" title="<spring:message code='label.tips.edit_post'/>">
                <i class="icon-edit"></i>
                <spring:message code="label.edit"/>
              </a>
            </c:if>
          </sec:authorize>
            <%--Edit post button end --%>
            <%--Delete post button start --%>
          <sec:authorize access="isAuthenticated()">
            <sec:authentication property="principal.id" var="userId"/>
            <c:set var="isDeleteButtonAvailable" value="false"/>
            <c:choose>
              <%--Controls for the first post, they affect topic--%>
              <c:when test="${isFirstPost}">
                <c:set var="isDeleteButtonAvailable"
                       value='${userId == post.userCreated.id && postsPage.numberOfElements == 1}'/>
                <c:set var="isDeleteButtonAvailable" value="true"/>
              </c:when>
              <%--Controls for the any other ordinaru post--%>
              <c:otherwise>
                <%--The ability of users to remove their own posts--%>
                <c:if test='${userId == post.userCreated.id}'>
                    <c:set var="isDeleteButtonAvailable" value="true"/>
                </c:if>
                <%--The ability of users to remove posts of the other users(for moderators and admins)--%>
                <c:if test='${userId != post.userCreated.id}'>
                  <c:set var="isDeleteButtonAvailable" value="true"/>
                </c:if>
              </c:otherwise>
            </c:choose>
            <c:if test="${isDeleteButtonAvailable}">
              <a href="${delete_url}" class="btn btn-mini btn-danger delete"
                 title="<spring:message code='label.tips.remove_post'/>"
                 data-confirmationMessage="<spring:message code='${confirm_message}'/>">
                <i class="icon-remove icon-white"></i>
                <spring:message code="label.delete"/>
              </a>
            </c:if>
          </sec:authorize>
            <%--Delete post button end --%>
        </div>


        <div class="btn-group">
          <a class="btn btn-mini postLink"
             title="<spring:message code='label.tips.link_to_post'/>"
             href="${pageContext.request.contextPath}/posts/${post.id}">
            <i class="icon-link"></i>
          </a>
          <c:if test='${!question.closed || hasCloseTopicPermission}'>
              <a class="btn btn-mini" onmousedown="quote(${post.id}, ${i.index})"
                 title="<spring:message code='label.tips.quote_post'/>">
                <i class="icon-quote"></i><spring:message code="label.quotation"/>
              </a>
          </c:if>
        </div>
      </div>
    </td>
  </tr>
  <tr class="post-content-tr">
    <td class="userinfo">
      <div>
        <p>
          <spring:message var="onlineTip" code="label.tips.user_online"/>
          <spring:message var="offlineTip" code="label.tips.user_offline"/>
          <c:set var="online" value='<i class="icon-online" title="${onlineTip}"></i>'/>
          <c:set var="offline" value='<i class="icon-offline" title="${offlineTip}"></i>'/>
          <jtalks:ifContains collection="${usersOnline}" object="${post.userCreated}"
                             successMessage="${online}" failMessage="${offline}"/>
          <a class='post-userinfo-username'
             href="${pageContext.request.contextPath}/users/${post.userCreated.id}"
             title="<spring:message code='label.tips.view_profile'/>">
            <c:out value="${post.userCreated.username}"/>
          </a>
        </p>
      </div>
             
                   <span class="thumbnail post-userinfo-avatal wraptocenter">
                        <img src="${pageContext.request.contextPath}/users/${post.userCreated.id}/avatar" alt=""/>
                   </span>

      <div>
        &nbsp;<br/>
        <div>
          <spring:message code="label.topic.message_count"/>
          <span class="space-left-small"><c:out value="${post.userCreated.postCount}"/></span>
        </div>
        <sec:authorize access="isAuthenticated()">
          <sec:authentication property="principal.id" var="userId"/>
          <jtalks:hasPermission targetId='${userId}' targetType='USER'
                                permission='ProfilePermission.SEND_PRIVATE_MESSAGES'>
            <c:if test='${userId != post.userCreated.id}'>
              <div>
                <a href="${pageContext.request.contextPath}/pm/new?recipientId=${post.userCreated.id}"
                   title='<spring:message code="label.pm.send"/>'>
                  <img alt='<spring:message code="label.pm.send"/>' src="${pageContext.request.contextPath}/resources/images/message-icon.png"/>
                </a>
              </div>
            </c:if>
          </jtalks:hasPermission>
        </sec:authorize>
      </div>
    </td>
    <td class='post-content-td'>
      <jtalks:postContent text="${post.postContent}"
                          signature="${post.userCreated.signature}"/>
    </td>
  </tr>
  <tr class="post-header">
    <td>
    </td>
    <td class="left-border">
      <jtalks:postFooterContent modificationDate="${post.modificationDate}"/>
    </td>
  </tr>
</table>
</div>
<%-- END OF Post --%>
</c:forEach>
</div>

<div class="row-fluid forum-pagination-container">
  <div class="span3">
    <%--<jtalks:topicControls topic="${question}"/>--%>
    &nbsp; <%-- For proper pagination layout without buttons--%>
  </div>

  <%-- Pagination --%>
  <div class="span9">
    <div class="pagination pull-right forum-pagination">
      <ul>
        <jtalks:pagination uri="${topicId}" page="${postsPage}"/>
      </ul>
    </div>
  </div>
  <%-- END OF Pagination --%>
</div>

<%-- Users --%>
<div id="users-stats" class="well forum-user-stats-container">
  <%--<jtalks:moderators moderators="${question.branch.moderatorsGroup.users}"/>--%>
  <br/>
  <strong><spring:message code="label.topic.now_browsing"/></strong>
  <%--<jtalks:users users="${viewList}" branch="${question.branch}"/>--%>
</div>
<%-- END OF Users --%>

<%--Fake form to delete posts and topics.
Without it we're likely to get lots of problems simulating HTTP DELETE via JS in a Spring fashion  --%>
<form:form id="deleteForm" method="DELETE"/>
</div>

<script>
  if ($('#bodyText\\.errors:visible').length > 0) {
    Utils.focusFirstEl('#postBody');
  }
</script>
</body>